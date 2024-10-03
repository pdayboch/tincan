import Link from 'next/link';

export default function Page() {
  return (
    <div className="max-w-4xl mx-auto py-10">
      <h1 className="text-3xl font-bold mb-8 text-center">Configuration Settings</h1>
      <nav>
        <ul className="flex flex-col items-center space-y-4">
          <li>
            <Link
              className="text-lg text-blue-500 border-2 border-blue-500 py-2 px-6 rounded-lg hover:bg-blue-500 hover:text-white transition-colors duration-300"
              href="/configurations/users"
            >
              Configure Users
            </Link>
          </li>
          <li>
            <Link
              className="text-lg text-blue-500 border-2 border-blue-500 py-2 px-6 rounded-lg hover:bg-blue-500 hover:text-white transition-colors duration-300"
              href="/configurations/categorization-rules"
            >
              Configure Categorization Rules
            </Link>
          </li>
          <li>
            <Link
              className="text-lg text-blue-500 border-2 border-blue-500 py-2 px-6 rounded-lg hover:bg-blue-500 hover:text-white transition-colors duration-300"
              href="/configurations/categories"
            >
              Configure Categories
            </Link>
          </li>
        </ul>
      </nav>
    </div>
  );
}
