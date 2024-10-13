import { PlusIcon } from "@heroicons/react/16/solid";
import AddRuleButton from "./components/AddRuleButton";

interface NoRulesComponentProps {
  onAddNewRule: () => void;
}

export default function NoRulesComponent({
  onAddNewRule
}: NoRulesComponentProps) {
  return (
    <div className="flex flex-col items-center justify-center \
                      border rounded-2xl px-14 py-8 w-3/4 \
                      mx-auto max-w-xl space-y-4 \
                      bg-white shadow-lg"
    >
      <p className="text-lg text-center mb-12">
        You don't have any auto-categorization rules configured yet!</p>
      <AddRuleButton
        label={"Add one now"}
        onClick={onAddNewRule}
      />
    </div>
  );
}