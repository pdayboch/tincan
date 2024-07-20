import Image from 'next/image';
import { Inter } from 'next/font/google';
import NavLinks from './NavLinks';

const inter = Inter({ weight:["500"], subsets:['latin'] });

export default function topNav() {
  return(
    <nav className="bg-theme-lgt-green border-gray-100 dark:bg-gray-500">
      <div className="flex flex-wrap items-center mx-auto pl-4 pr-4 pt-4 pb-2">
        <a href="https://127.0.0.1:3001/dashboard" className="flex items-center space-x-3 rtl:space-x-reverse pr-10">
          <Image
            src="/tincan_logo.png"
            width={60}
            height={60}
            alt="Logo"
            style={{ width: 'auto', height: 'auto' }}
            priority
          />
          <span className="self-center text-3xl font-semibold whitespace-nowrap dark:text-white">
            Tincan
          </span>
        </a>
        <NavLinks />
      </div>
    </nav>
  );
}