import requests
import base64
import re
from flask import Flask
import os
github_key = os.getenv("GITHUB_KEY")
if github_key is None:
    raise Exception("请设置环墇变量 GITHUB_KEY")

def decode_base64(encoded):
    return base64.b64decode(encoded).decode('utf-8')

def get_readme_content(repo = "movefuns/SuiStartrek"):
    url = f"https://api.github.com/repos/{repo}/contents/README.md"
    headers = {
        "Accept":"application/vnd.github+json",
        "Authorization":f"Bearer {github_key}",
        "X-GitHub-Api-Version":"2022-11-28",
    }
    res = requests.get(url,headers=headers)
    tmp = res.json()
    return decode_base64(tmp["content"]).replace("\n","")


def get_string_between(text, start_str, end_str):
    pattern = re.escape(start_str)
    if end_str:
       pattern += r'(.*?)'+ re.escape(end_str)
    else:
        pattern += r'(.*)'
    match = re.search(pattern, text)
    return match.group(1) if match else ""

def parse_github(text):
    '''
    规则解析readme
    '''
    # 使用正则表达式匹配GitHub仓库链接
    pattern = r'https?://(?:www\.)?github\.com/[\w\-]+/[\w\-]+'
    matches = re.findall(pattern, text)
    return list(set(matches))

def parse_move_did(text):
    data = get_string_between(text, "# move_did", "#")
    print("data",data)
    pattern = r'0x[0-9a-fA-F]{64}'
    matches = re.findall(pattern, data)
    return matches[0] if len(matches)>0 else ""

def parse_donate(text):
    data = get_string_between(text, "# donate", "#")
    pattern = r'\w+'
    matches = re.findall(pattern, data)
    return list(set(matches))

def parse_contributors(text):
    data = get_string_between(text, "# contributors", "#")
    pattern = r'0x[0-9a-fA-F]{64}'
    matches = re.findall(pattern, data)
    return list(set(matches))

# 创建 Flask 应用
app = Flask(__name__)

# 定义路由
@app.route('/github.com/<name>/<repo>')
def github_readme_parse(name,repo):
    if name is None or repo is None:
        return {
            "code":1,
            "data":{},
            "msg":"参数错误"
        }
    content = get_readme_content(f"{name}/{repo}")
    donates = [{
        x.split(" ")[0]:float(x.split(" ")[1])
    } for x in parse_donate(content)]
    return {
        "code":0,
        "data":{
            "aptos_addr":parse_move_did(content),
            "donate":donates,
            "contributors":parse_contributors(content),
            "repos":parse_github(content),
        },
        "msg":"ok"
    }


# 运行应用
if __name__ == '__main__':
    app.run(host="0.0.0.0",port=8000,debug=True)