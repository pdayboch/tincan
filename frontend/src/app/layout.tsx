import './globals.css'
import { lusitana } from '@/app/fonts';
import TopNav from './ui/nav/TopNav';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${lusitana.className} antialiased`}>
        <div className="w-full flex-none">
          <TopNav />
        </div>
        <div className="pl-8 pr-8">
          {children}
        </div>
      </body>
    </html>
  );
}
