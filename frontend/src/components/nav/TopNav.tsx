import Image from 'next/image';
import { Abril_Fatface } from 'next/font/google';
import NavLinks from './NavLinks';
import clsx from 'clsx';

const font = Abril_Fatface({ weight: ["400"], subsets: ['latin'] });

export default function topNav() {
  return (
    <nav className="bg-theme-lgt-green border-gray-100 dark:bg-gray-500">
      <div className="flex flex-none items-center mx-auto pl-4 pr-4 pt-4 pb-2">
        <a href="http://127.0.0.1:3000/dashboard" className="flex items-center space-x-3 rtl:space-x-reverse pr-10">
          <Image
            src="/tincan_logo.png"
            width={60}
            height={60}
            alt="Logo"
            style={{ width: 'auto', height: 'auto' }}
            priority
          />
          <span className={clsx("self-center text-4xl font-semibold whitespace-nowrap dark:text-white", font.className)}>
            Tincan
          </span>
        </a>
        <NavLinks />
      </div>
    </nav>
  );
}