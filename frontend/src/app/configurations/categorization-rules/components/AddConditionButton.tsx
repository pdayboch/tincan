import { PlusIcon } from "@heroicons/react/16/solid";

interface AddConditionButtonProps {
  onClick: () => void;
}

export const AddConditionButton: React.FC<AddConditionButtonProps> = ({ onClick }) => {
  return (
    <button
      onClick={onClick}
      className="flex items-center px-4 py-2 rounded-lg \
                  bg-theme-lgt-green hover:bg-theme-drk-green \
                  active:bg-theme-pressed-green active:scale-95 \
                  transition-transform duration-150"
    >
      <PlusIcon className="w-5 h-5 mr-2" />
      Add a condition
    </button>
  );
};