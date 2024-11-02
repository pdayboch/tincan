import { Account, CategorizationCondition } from "@/lib/definitions";
import clsx from "clsx";
import { MATCH_TYPES_FOR_FIELDS } from "../utils/formatting-helpers";
import ConditionMatchValueInput from "./ConditionMatchValueInput";

interface EditableCategorizationConditionProps {
  condition: CategorizationCondition;
  accounts: Account[];
  onUpdate: (updatedCondition: CategorizationCondition) => void;
  onDelete: () => void;
  setToDelete: boolean;
}

export default function EditableCategorizationCondition({
  condition,
  accounts,
  onUpdate,
  onDelete,
  setToDelete
}: EditableCategorizationConditionProps) {
  // Dynamically set match types based on the selected transactionField
  const matchTypeOptions = MATCH_TYPES_FOR_FIELDS[condition.transactionField];

  const handleFieldChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const newTransactionField = e.target.value;

    onUpdate({
      ...condition,
      transactionField: newTransactionField,
      matchType: "",
      matchValue: ""
    });
  };

  const handleMatchTypeChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    onUpdate({ ...condition, matchType: e.target.value });
  };

  const handleMatchValueChange = (newValue: string) => {
    onUpdate({ ...condition, matchValue: newValue });
  };

  // Validation: check if matchType or matchValue is empty
  const isMatchTypeInvalid = condition.matchType === "";
  const isMatchValueInvalid = condition.matchValue === "";

  return (
    <div
      className={clsx(
        "relative flex flex-col space-y-2 p-4 bg-gray-100 rounded-lg",
        setToDelete && "line-through bg-red-50"
      )}
    >

      {/* X (delete) button */}
      <button
        className={clsx(
          "absolute top-2 right-2 px-4 py-1 text-xl rounded-full",
          "text-gray-500 transition-colors",
          setToDelete ?
            "cursor-not-allowed" :
            "hover:text-gray-700 hover:bg-gray-200 transition-colors"
        )}
        onClick={onDelete}
        disabled={setToDelete}
        title={setToDelete ? "Marked for deletion" : "Delete condition"}
      >
        &times;
      </button>

      <div className="flex flex-wrap justify-start items-center gap-2">
        <span className="text-gray-700">when transaction's</span>

        {/* Transaction Field dropdown */}
        <select
          className="w-full md:w-48 border border-gray-300 rounded p-2 h-[40px] \
                      bg-white text-gray-700"
          value={condition.transactionField}
          onChange={handleFieldChange}
          disabled={setToDelete}
        >
          {Object.keys(MATCH_TYPES_FOR_FIELDS).map((field) => (
            <option key={field} value={field}>
              {field}
            </option>
          ))}
        </select>
      </div>

      <div className="flex flex-wrap justify-start items-center gap-2">
        {/* Match Type dropdown */}
        <select
          className={clsx(
            "w-full md:w-48 border rounded border-gray-300 p-2 h-[40px]",
            "bg-white text-gray-700",
            isMatchTypeInvalid && "border-red-500"
          )}
          value={condition.matchType}
          onChange={handleMatchTypeChange}
          disabled={setToDelete}
        >
          <option value="" disabled>Select a match type</option>
          {Object.entries(matchTypeOptions).map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </select>

        {/* Match Value input */}
        <ConditionMatchValueInput
          value={condition.matchValue}
          transactionField={condition.transactionField}
          accounts={accounts}
          onChange={handleMatchValueChange}
          isDisabled={setToDelete}
          isInvalid={isMatchValueInvalid}
        />
      </div>
    </div>
  );
}
