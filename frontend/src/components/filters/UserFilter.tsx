import { User } from "@/lib/definitions";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import Select, { MultiValue } from 'react-select';

interface UserFilterProps {
  users: User[];
}

type OptionType = {
  id: number,
  value: number,
  label: string
};

const PARAM_NAME = 'users[]';

export default function UserFilter({
  users
}: UserFilterProps) {
  const [selectedUsers, setSelectedUsers] = useState<OptionType[]>([]);
  const userOptions = users.map((user) => ({
    id: user.id,
    value: user.id,
    label: user.name,
  }));

  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  useEffect(() => {
    const param = searchParams.getAll(PARAM_NAME);
    const newSelectedUsers = userOptions.filter(options =>
      param.includes(String(options.value))
    );

    setSelectedUsers(newSelectedUsers);
  }, [searchParams]);


  const handleSelectionChange = (
    selectedOptions: MultiValue<OptionType>
  ) => {
    const params = new URLSearchParams(searchParams);
    // Reset pagination to page 1
    params.delete('startingAfter');
    params.delete('endingBefore');

    // Update url param
    if (selectedOptions.length > 0) {
      const selectedIds = selectedOptions.map(option =>
        String(option.value)
      );
      params.delete(PARAM_NAME);
      selectedIds.forEach(id => params.append(PARAM_NAME, id))
    } else {
      params.delete(PARAM_NAME);
    }

    replace(`${pathname}?${params.toString()}`)
  };

  return (
    <Select
      instanceId="user-filter-select"
      options={userOptions}
      isMulti
      isSearchable
      placeholder="All Users"
      onChange={handleSelectionChange}
      value={selectedUsers}
    />
  );
}