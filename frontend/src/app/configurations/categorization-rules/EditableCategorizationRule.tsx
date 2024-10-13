import { useState } from 'react';
import { TrashIcon, ArrowUturnLeftIcon, CheckIcon } from '@heroicons/react/24/solid';
import {
  CategorizationRule,
  CategorizationCondition,
  CategorizationConditionUpdate,
  Category,
  Account,
  CategorizationRuleUpdate
} from '@/lib/definitions';
import EditableCategorizationCondition from './EditableCategorizationCondition';
import CategoryDropdown from '@/components/category/CategoryDropdown';
import { AddConditionButton } from './components/AddConditionButton';
import { findSubcategoryId, findSubcategoryNameById } from '@/lib/helpers';
import { areConditionsEqual, EMPTY_CONDITION } from './utils/rule-helpers';
import {
  deleteCategorizationRule,
  updateCategorizationRule
} from '@/lib/api/categorization-rule-api';
import {
  createCategorizationCondition,
  deleteCategorizationCondition
} from '@/lib/api/categorization-condition-api';

interface EditableCategorizationRuleProps {
  rule: CategorizationRule;
  categories: Category[];
  accounts: Account[];
  onCancel: () => void;
  onSave: (updatedRule: CategorizationRule) => void;
  onDelete: () => void;
}

export default function EditableCategorizationRule({
  rule,
  categories,
  accounts,
  onCancel,
  onSave,
  onDelete
}: EditableCategorizationRuleProps) {
  const [subcategoryId, setSubcategoryId] = useState<number>(rule.subcategory.id);
  const [newConditions, setNewConditions] = useState<CategorizationCondition[]>([]);
  const [newConditionIndex, setNewConditionIndex] = useState<number>(1);
  const [deletedConditionIds, setDeletedConditionIds] = useState<number[]>([]);
  const [updatedConditions, setUpdatedConditions] = useState<CategorizationCondition[]>([]);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  const doBulkUpdate = async (): Promise<CategorizationRule> => {
    // Merge in updated conditions
    const mergedConditions = nonDeletedConditions().map((condition) => {
      const updatedCondition = updatedConditions.find(
        (updated) => updated.id === condition.id
      );
      return updatedCondition || condition;
    });

    // Add new conditions
    const allConditions = [...mergedConditions, ...newConditions];

    const conditionsForUpdate = allConditions.map((condition) => ({
      transactionField: condition.transactionField,
      matchType: condition.matchType,
      matchValue: condition.matchValue
    }));

    const updateData: CategorizationRuleUpdate = {
      subcategoryId: subcategoryId !== rule.subcategory.id ? subcategoryId : undefined,
      conditions: conditionsForUpdate.length > 0 ? conditionsForUpdate : undefined
    };

    return await updateCategorizationRule(rule.id, updateData);
  };

  const nonDeletedConditions = (): CategorizationCondition[] => {
    return rule.conditions.filter(
      (condition) => !deletedConditionIds.includes(condition.id)
    );
  }

  const convertConditionToConditionUpdateObject = (
    condition: CategorizationCondition
  ): CategorizationConditionUpdate => {
    const { transactionField, matchType, matchValue } = condition;
    return {
      transactionField,
      matchType,
      matchValue
    };
  };

  const doCreateConditions = async () => {
    for (const condition of newConditions) {
      const conditionData = convertConditionToConditionUpdateObject(condition);
      await createCategorizationCondition(rule.id, conditionData);
    }
  };

  const doDeleteConditions = async () => {
    for (const id of deletedConditionIds) {
      await deleteCategorizationCondition(id);
    }
  }

  const handleRuleSave = async () => {
    try {
      // Check if subcategory or any conditions were updated
      // and if so, do everything in bulk update
      if (
        rule.subcategory.id !== subcategoryId ||
        updatedConditions.length > 0
      ) {
        const updatedRule = await doBulkUpdate();
        onSave(updatedRule);
        return;
      }

      let finalUpdatedRule = { ...rule };
      // No bulk update performed so:
      // Handle new conditions (if any)
      if (newConditions.length > 0) {
        await doCreateConditions();
        finalUpdatedRule.conditions = [...finalUpdatedRule.conditions, ...newConditions];
      }

      // Gandle deleted conditions (if any)
      if (deletedConditionIds.length > 0) {
        await doDeleteConditions();
        finalUpdatedRule.conditions = finalUpdatedRule.conditions.filter(
          (condition) => !deletedConditionIds.includes(condition.id)
        );
      }

      // create the most up to date rule to pass up to the parent.
      onSave(finalUpdatedRule);
    } catch (error) {
      console.error("Error saving rule: ", error);
    }
  };

  const handleDeleteRule = async () => {
    try {
      await deleteCategorizationRule(rule.id);
      onDelete();
    } catch (error) {
      console.error("Error deleting rule: " + error);
    }
  };

  // when we update the subcategory selector to return ids instead
  // of names, we can remove this and set the state id directly.
  const handleSubcategoryUpdate = (newSubcategoryName: string) => {
    const id = findSubcategoryId(categories, newSubcategoryName)
    if (id) setSubcategoryId(id);
  };

  const emptyConditionWithId = (id: number): CategorizationCondition => {
    return { ...EMPTY_CONDITION, id: id };
  };

  const handleAddNewCondition = () => {
    setNewConditions([...newConditions, emptyConditionWithId(newConditionIndex)]);
    setNewConditionIndex((index) => index + 1)
  };

  const syncNewCondition = (updatedNewCondition: CategorizationCondition) => {
    console.log("syncing new condition:", updatedNewCondition);
    setNewConditions((conditions) => {
      // lookup condition from newConditions array
      const index = conditions.findIndex(
        (condition) => condition.id === updatedNewCondition.id
      );

      if (index > -1) {
        const tempNewConditions = [...conditions];
        tempNewConditions[index] = updatedNewCondition;
        return tempNewConditions;
      }
      return conditions;
    });
  };

  const handleDeleteNewCondition = (id: number) => {
    setNewConditions((conditions) =>
      conditions.filter((condition) => condition.id !== id))
  };

  const findOriginalCondition = (id: number): CategorizationCondition | undefined => {
    return rule.conditions.find((condition) => condition.id === id);
  };

  const removeConditionFromUpdated = (id: number) => {
    setUpdatedConditions((conditions) =>
      conditions.filter((condition) => condition.id !== id)
    );
  };

  const syncUpdatedCondition = (updatedCondition: CategorizationCondition) => {
    setUpdatedConditions((conditions) => {
      const existingConditionIndex = conditions.findIndex(
        (condition) => condition.id === updatedCondition.id
      );

      if (existingConditionIndex > -1) {
        const updatedConditions = [...conditions];
        updatedConditions[existingConditionIndex] = updatedCondition
        return updatedConditions;
      } else {
        return [...conditions, updatedCondition];
      }
    });
  };

  const handleConditionUpdate = (updatedCondition: CategorizationCondition): void => {
    const originalCondition = findOriginalCondition(updatedCondition.id);
    if (
      originalCondition &&
      areConditionsEqual(originalCondition, updatedCondition)
    ) {
      removeConditionFromUpdated(updatedCondition.id);
    } else {
      syncUpdatedCondition(updatedCondition);
    }
  };

  const handleConditionDelete = (id: number) => {
    setDeletedConditionIds((prevIds) => [id, ...prevIds]);
    removeConditionFromUpdated(id);
  };

  const getLatestCondition = (condition: CategorizationCondition) => {
    // Check if the condition has an update
    const updatedCondition = updatedConditions.find(c => c.id === condition.id);
    return updatedCondition || condition;
  };

  return (
    <div className='border border-gray-300 rounded-3xl w-full p-6 mb-6 shadow-lg bg-white'>
      <div className='space-y-4'>

        {/* Render existing conditions */}
        {rule.conditions.map((condition, index) => {
          const latestCondition = getLatestCondition(condition);

          return (
            <div key={condition.id}>
              <EditableCategorizationCondition
                key={condition.id}
                condition={latestCondition}
                accounts={accounts}
                onUpdate={handleConditionUpdate}
                onDelete={() => handleConditionDelete(condition.id)}
                setToDelete={deletedConditionIds.includes(condition.id)}
              />
              {index < rule.conditions.length - 1 && (
                <div className="relative flex items-center justify-center my-4">
                  <hr className="w-full border-gray-300" />
                  <span className="absolute px-2 text-sm text-gray-500 bg-white">AND</span>
                </div>
              )}
            </div>
          );
        })}

        {/* Render new conditions */}
        {newConditions.map((condition, index) => (
          <div key={condition.id}>
            <EditableCategorizationCondition
              key={condition.id}
              condition={condition}
              accounts={accounts}
              onUpdate={syncNewCondition}
              onDelete={() => handleDeleteNewCondition(condition.id)}
              setToDelete={false}
            />
            {index < newConditions.length - 1 && (
              <div className="relative flex items-center justify-center my-4">
                <hr className="w-full border-gray-300" />
                <span className="absolute px-2 text-sm text-gray-500 bg-white">AND</span>
              </div>
            )}
          </div>
        ))}

        {/* Add extra horizontal line and the AddConditionButton below last condition */}
        <div className="relative flex items-center justify-center my-4">
          <hr className="w-full border-gray-300" />
        </div>

        <div className="w-full flex justify-center">
          <AddConditionButton
            onClick={handleAddNewCondition}
          />
        </div>

        {/* Subcategory selector */}
        <div className="flex items-center mt-6 p-4 bg-blue-50 text-blue-900 rounded-lg">
          <span className="font-medium">Then assign subcategory: </span>
          <div className="ml-2 flex-grow">
            <CategoryDropdown
              categories={categories}
              currentCategory={findSubcategoryNameById(categories, subcategoryId)}
              onChange={handleSubcategoryUpdate}
            />
          </div>
        </div>
      </div>

      {/* Action buttons (Save, Cancel) */}
      < div className="mt-6 flex justify-between" >
        {/* Delete Button: Separated on the left */}
        < button
          onClick={() => setShowDeleteConfirm(true)}
          className="flex items-center bg-red-400 text-white px-3 py-2 rounded-md hover:bg-red-500"
        >
          <TrashIcon className="w-5 h-5 mr-1" />
          Delete
        </button>

        {/* Cancel and Save Buttons: Grouped on the right */}
        <div className="flex space-x-4">
          <button
            onClick={onCancel}
            className="flex items-center text-gray-500 hover:text-gray-700"
          >
            <ArrowUturnLeftIcon className="w-5 h-5 mr-1" />
            Cancel
          </button>

          <button
            onClick={handleRuleSave}
            className="flex items-center bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600"
          >
            <CheckIcon className="w-5 h-5 mr-1" />
            Save Rule
          </button>
        </div>
      </div>

      {/* Delete Confirmation Dialog */}
      {showDeleteConfirm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
          <div className="bg-white p-6 rounded-md shadow-lg">
            <h3 className="text-lg font-semibold">Are you sure?</h3>
            <p className="mt-2 text-sm text-gray-600">This action cannot be undone.</p>
            <div className="mt-4 flex justify-end space-x-4">
              <button
                onClick={() => setShowDeleteConfirm(false)}
                className="px-4 py-2 text-gray-600 hover:text-gray-800"
              >
                Cancel
              </button>
              <button
                onClick={handleDeleteRule}
                className="px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600"
              >
                Confirm Delete
              </button>
            </div>
          </div>
        </div>
      )
      }
    </div >
  );
}