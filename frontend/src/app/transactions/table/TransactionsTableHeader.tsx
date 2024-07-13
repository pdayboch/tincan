export default function TransactionsTableHeader() {
  return (
    <thead className="rounded-lg text-left text-md font-normal">
      <tr>
        <th scope="col" className="px-2 py-4 font-medium">
          Date
        </th>
        <th scope="col" className="px-3 py-4 font-medium">
          Description
        </th>
        <th scope="col" className="px-3 py-4 font-medium">
          Account
        </th>
        <th scope="col" className="px-3 py-4 font-medium">
          User
        </th>
        <th scope="col" className="px-3 py-4 font-medium">
          Category
        </th>
        <th scope="col" className="px-3 py-4 font-medium">
          Amount
        </th>
        <th scope="col" className="px-3 py-4">
          <span className="sr-only">Edit</span>
        </th>
      </tr>
    </thead>
  );
}