export default function TransactionsTableHeader() {
  return (
    <thead className="rounded-lg text-left text-sm font-normal">
      <tr>
        <th scope="col" className="px-2 py-5 font-medium">
          Date
        </th>
        <th scope="col" className="px-3 py-5 font-medium sm:pl-6">
          Description
        </th>
        <th scope="col" className="px-3 py-5 font-medium">
          Account
        </th>
        <th scope="col" className="px-3 py-5 font-medium">
          User
        </th>
        <th scope="col" className="px-3 py-5 font-medium">
          Category
        </th>
        <th scope="col" className="px-3 py-5 font-medium">
        </th>
        <th scope="col" className="px-3 py-5 font-medium">
          Amount
        </th>
        <th scope="col" className="relative py-3 pl-6 pr-3 w-8">
          <span className="sr-only">Edit</span>
        </th>
      </tr>
    </thead>
  );
}