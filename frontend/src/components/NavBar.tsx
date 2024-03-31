import Image from "next/image";
import { NavItem } from "./NavItem";
import { AptosConnect } from "./AptosConnect";
import {
  MODULE_URL
} from "../config/constants";

export function NavBar() {
  return (
    <nav className="navbar py-4 px-4 bg-base-100">
      <div className="flex-1">
        <a href="http://movedid.build" target="_blank">
          <Image src="/logo2.png" width={150} height={150} alt="logo" />
        </a>
        <ul className="menu menu-horizontal p-0 ml-5">
        <NavItem href="/" title="User" />
          <NavItem href="/repo" title="Repo" />
          <NavItem href="/donate" title="Donate" />
          <NavItem href="/chat_msg" title="Chat" />
          <NavItem href="/repo_point" title="Point" />
          <NavItem href="/airdrop" title="Airdrop" />
        </ul>
      </div>
      <AptosConnect />
    </nav>
  );
}
