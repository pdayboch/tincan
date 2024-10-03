interface PageSizeDropdownProps {
  pageSize: number;
  handlePageSizeChange: (event: React.ChangeEvent<HTMLSelectElement>) => void;
}

export default function PageSizeDropdown({
  pageSize, handlePageSizeChange
}: PageSizeDropdownProps) {
    return (
    <div>
      <label htmlFor="pageSize" className="mr-2">Items per page:</label>
      <select
        id="pageSize"
        value={pageSize}
        onChange={handlePageSizeChange}
        className="px-2 py-1 border rounded"
      >
        <option value={10}>10</option>
        <option value={25}>25</option>
        <option value={35}>35</option>
        <option value={50}>50</option>
      </select>
    </div>
  );
}