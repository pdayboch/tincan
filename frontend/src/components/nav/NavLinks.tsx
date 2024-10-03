"use client"

import { TableCellsIcon, ChartPieIcon, CreditCardIcon, Cog6ToothIcon } from '@heroicons/react/24/outline';
import { Inter } from 'next/font/google';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import clsx from 'clsx';

const inter = Inter({ weight: ["500"], subsets: ['latin'] });

const links = [
  {
    name: 'Transactions',
    href: '/transactions',
    icon: TableCellsIcon
  },
  {
    name: 'Trends',
    href: '/trends',
    icon: ChartPieIcon
  },
  {
    name: 'Accounts',
    href: '/accounts',
    icon: CreditCardIcon
  },
  {
    name: 'Configurations',
    href: '/configurations',
    icon: Cog6ToothIcon
  }
];

export default function NavLinks() {
  const pathname = usePathname();
  return (
    <div className={clsx("flex", inter.className)}>
      {links.map((link) => {
        const LinkIcon = link.icon;
        return (
          <Link
            key={link.name}
            href={link.href}
            className={clsx(
              'flex h-[48px] items-center justify-center gap-2 rounded-md mr-7 text-gray-900 dark:text-white hover:underline text-md',
              {
                'text-theme-drk-orange': pathname === link.href,
              }
            )}
          >
            <div className="flex flex-row">
              <LinkIcon className="w-7 h-7 pr-1" aria-hidden="true" />
              <p className="hidden md:block">{link.name}</p>
            </div>
          </Link>
        );
      })}
    </div>
  );
}