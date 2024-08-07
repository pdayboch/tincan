import { useRouter, useSearchParams, usePathname } from 'next/navigation';
import { useEffect, useState } from 'react';
import PageSizeDropdown from './PageSizeDropdown';

interface PaginationBarProps {
  prevPage: string | null;
  nextPage: string | null;
}

export default function PaginationBar({
  prevPage, nextPage
}: PaginationBarProps) {
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  const [pageSize, setPageSize] = useState<number>(10);

  useEffect(() => {
    const pageSizeParam = searchParams.get('pageSize');
    if (pageSizeParam) {
      setPageSize(parseInt(pageSizeParam, 10));
    }
  }, [searchParams]);

  const handlePageSizeChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
    const newPerPage = parseInt(event.target.value, 10);
    setPageSize(newPerPage);
    const params = new URLSearchParams(searchParams.toString());
    params.set('pageSize', newPerPage.toString());
    params.delete('startingAfter');
    params.delete('endingBefore');
    replace(`${pathname}?${params.toString()}`);
  };

  const handlePrevPageClick = () => {
    if (prevPage) {
      const params = new URLSearchParams(searchParams);
      params.delete('startingAfter');
      params.set('endingBefore', prevPage);
      replace(`${pathname}?${params.toString()}`);
    }
  };

  const handleNextPageClick = () => {
    if (nextPage) {
      const params = new URLSearchParams(searchParams);
      params.delete('endingBefore');
      params.set('startingAfter', nextPage);
      replace(`${pathname}?${params.toString()}`);
    }
  };

  return (
    <div className="pagination-bar flex justify-between mt-4">
      <PageSizeDropdown pageSize={pageSize} handlePageSizeChange={handlePageSizeChange} />
      <button
        onClick={handlePrevPageClick}
        disabled={!prevPage}
        className={`px-4 py-2 rounded ${!prevPage ? 'bg-gray-300' : 'bg-blue-500 text-white'}`}
      >
        Previous
      </button>
      <button
        onClick={handleNextPageClick}
        disabled={false}
        className={`px-4 py-2 rounded ${!nextPage ? 'bg-gray-300' : 'bg-blue-500 text-white'}`}
      >
        Next
      </button>
    </div>
  );
}