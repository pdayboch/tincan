import { PlayIcon } from "@heroicons/react/16/solid";

interface ApplyRulesButtonProps {
  onClick: () => void;
}

export default function ApplyRulesButton({ onClick }: ApplyRulesButtonProps) {
  return (
    <div className="flex flex-col items-center space-y-1">
      {/* Label above button */}
      <span className="text-sm text-gray-600 text-center md:text-left">
        Apply rules to uncategorized transactions
      </span>

      <button
        className="inline-flex items-center justify-center \
                    h-10 w-full max-w-xs px-4 py-2 border rounded-lg \
                    bg-theme-lgt-green hover:bg-theme-drk-green \
                    active:bg-theme-pressed-green active:scale-95 \
                    active:shadow-inner cursor-pointer"
        onClick={onClick}
      >
        <PlayIcon className="h-5 w-5 mr-2" />
        <span>Apply</span>
      </button>
    </div>
  );
}