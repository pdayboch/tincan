export default function TransactionsHeader() {
  return (
    <thead className="rounded-lg text-left text-md font-normal">
      <tr>
        <th scope="col" className="w-24 px-2 py-3 font-medium">
          Date
        </th>
        <th scope="col" className="w-64 px-2 py-3 font-medium">
          Description
        </th>
        <th scope="col" className="w-48 px-2 py-3 font-medium">
          Category
        </th>
        <th scope="col" className="w-24 px-2 py-3 font-medium">
          Amount
        </th>
        <th scope="col" className="w-4 px-2 py-3">
          <span className="sr-only">Edit</span>
        </th>
      </tr>
    </thead>
  );
}