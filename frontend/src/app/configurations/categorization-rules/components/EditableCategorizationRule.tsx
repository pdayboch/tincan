import { useEffect, useState } from 'react';
import { TrashIcon, ArrowUturnLeftIcon, CheckIcon } from '@heroicons/react/24/solid';
import EditableCategorizationCondition from './EditableCategorizationCondition';
import { AddConditionButton } from './AddConditionButton';
import ErrorNotification from '@/components/errors/ErrorNotification';
import {
  CategorizationRule,
  CategorizationCondition,
  Category,
  Account,
  CategorizationRuleUpdate
} from '@/lib/definitions';
import {
  areConditionsEqual,
  convertConditionToConditionUpdateObject,
  emptyConditionWithId,
  validateCondition
} from '../utils/rule-helpers';
import {
  createCategorizationRule,
  deleteCategorizationRule,
  updateCategorizationRule
} from '@/lib/api/categorization-rule-api';
import {
  createCategorizationCondition,
  deleteCategorizationCondition
} from '@/lib/api/categorization-condition-api';
import clsx from 'clsx';
import SubcategorySelector from '@/components/category/SubcategorySelector';

interface EditableCategorizationRuleProps {
  rule: CategorizationRule;
  categories: Category[];
  accounts: Account[];
  onCancel: () => void;
  onSave: (updatedRule: CategorizationRule) => void;
  onDelete: () => void;
  isNewRule: boolean;
}

export default function EditableCategorizationRule({
  rule,
  categories,
  accounts,
  onCancel,
  onSave,
  onDelete,
  isNewRule
}: EditableCategorizationRuleProps) {
  const [localSubcategory, setLocalSubcategory] = useState<{ id: number, name: string }>(rule.subcategory);
  const [isSubcategoryValid, setIsSubcategoryValid] = useState<boolean>(true);
  const [newConditions, setNewConditions] = useState<CategorizationCondition[]>([]);
  const [newConditionIndex, setNewConditionIndex] = useState<number>(1);
  const [deletedConditionIds, setDeletedConditionIds] = useState<number[]>([]);
  const [updatedConditions, setUpdatedConditions] = useState<CategorizationCondition[]>([]);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setIsSubcategoryValid(checkSubcategoryValid());
  }, [localSubcategory]);

  const checkSubcategoryValid = (): boolean => {
    return categories.some(category =>
      category.subcategories.some(subcategory =>
        subcategory.id === localSubcategory.id
      )
    );
  };

  // Validate subcategory with error setting (for save action)
  const validateSubcategoryOnSave = () => {
    const isValid = checkSubcategoryValid();

    if (!isValid) {
      setError("Subcategory is required");
    }

    return isValid;
  };

  const nonDeletedConditions = (): CategorizationCondition[] => {
    return rule.conditions.filter(
      (condition) => !deletedConditionIds.includes(condition.id)
    );
  }

  const allCurrentConditions = (): CategorizationCondition[] => {
    // Merge in updated conditions
    const mergedConditions = nonDeletedConditions().map((condition) => {
      const updatedCondition = updatedConditions.find(
        (updated) => updated.id === condition.id
      );
      return updatedCondition || condition;
    });

    // Add new conditions
    return [...mergedConditions, ...newConditions];
  };

  const validateConditions = () => {
    for (const condition of allCurrentConditions()) {
      const error = validateCondition(condition);
      if (error) {
        setError(error);
        return false;
      }
    }
    return true; // All conditions are valid
  };

  const doBulkUpdate = async () => {
    const conditionsForUpdate = allCurrentConditions()
      .map(convertConditionToConditionUpdateObject);

    const updateData: CategorizationRuleUpdate = {
      subcategoryId: localSubcategory.id !== rule.subcategory.id ?
        localSubcategory.id : undefined,
      conditions: conditionsForUpdate.length > 0 ?
        conditionsForUpdate : undefined
    };
    try {
      const updatedRule = await updateCategorizationRule(rule.id, updateData);
      onSave(updatedRule);
    } catch (error) {
      console.error("Error bulk updating rule: ", error);
    }
  };

  const doCreateNewConditions = async (): Promise<CategorizationCondition[]> => {
    const createdConditions: CategorizationCondition[] = [];

    try {
      for (const condition of newConditions) {
        const conditionData = convertConditionToConditionUpdateObject(condition);
        const newCondition = await createCategorizationCondition(rule.id, conditionData);
        createdConditions.push(newCondition);
      }
    } catch (error) {
      console.error("Error creating conditions: ", error);
    }

    return createdConditions;
  };

  const doDeleteConditions = async () => {
    try {
      for (const id of deletedConditionIds) {
        await deleteCategorizationCondition(id);
      }
    } catch (error) {
      console.error("Error deleting conditions: ", error);
    }
  }

  const doCreateAndDeleteConditions = async () => {
    let finalUpdatedRule = { ...rule };

    // Handle new conditions (if any)
    if (newConditions.length > 0) {
      const createdConditions = await doCreateNewConditions();
      finalUpdatedRule.conditions = [
        ...finalUpdatedRule.conditions,
        ...createdConditions
      ];
    }

    // Handle deleted conditions (if any)
    if (deletedConditionIds.length > 0) {
      await doDeleteConditions();
      finalUpdatedRule.conditions = finalUpdatedRule.conditions.filter(
        (condition) => !deletedConditionIds.includes(condition.id)
      );
    }

    onSave(finalUpdatedRule);
  };

  const doCreateRule = async () => {
    const conditionsForUpdate = allCurrentConditions()
      .map(convertConditionToConditionUpdateObject);

    try {
      const createdRule = await createCategorizationRule({
        subcategoryId: localSubcategory.id,
        conditions: conditionsForUpdate
      });

      onSave(createdRule);
    } catch (error) {
      console.error("Error creating conditions: ", error);
    }
  };

  const handleRuleSave = async () => {
    // Step 1: validate the rule:
    if (!validateConditions() || !validateSubcategoryOnSave()) return;

    // If this is a new rule, create it
    if (isNewRule) return await doCreateRule();

    // Existing rule:
    // Use bulk update if subcategory or conditions were updated
    if (
      rule.subcategory.id !== localSubcategory.id ||
      updatedConditions.length > 0
    ) {
      return doBulkUpdate();
    }

    // No bulk update performed, create and delete conditions if necessary
    doCreateAndDeleteConditions();
  };

  const handleDeleteRule = async () => {
    if (isNewRule) return onDelete();

    try {
      await deleteCategorizationRule(rule.id);
      onDelete();
    } catch (error) {
      console.error("Error deleting rule: " + error);
    }
  };

  const handleAddNewCondition = () => {
    setNewConditions([...newConditions, emptyConditionWithId(newConditionIndex)]);
    setNewConditionIndex((index) => index + 1)
  };

  const syncNewCondition = (updatedNewCondition: CategorizationCondition) => {
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

  const handleConditionUpdate = (updatedCondition: CategorizationCondition) => {
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
    <div
      className={clsx(
        'border rounded-3xl w-full p-5 mb-6 shadow-lg bg-white',
        isNewRule ? 'border-green-500' : 'border-gray-300'
      )}
    >
      <div className='space-y-4'>

        {/* New Rule Badge */}
        {isNewRule && (
          <div className="flex justify-start mb-2">
            <span className="bg-green-100 text-green-800 text-sm font-semibold px-3 py-1 rounded-full">
              New Rule
            </span>
          </div>
        )}

        {/* Subcategory Section */}
        <div className="flex flex-col items-start p-3 mb-6 bg-blue-50 text-blue-900 rounded-lg">
          <div className="flex items-center w-full">
            <span className="font-medium">Assign subcategory: </span>
            <div
              className={clsx(
                "ml-3 flex-grow",
                !isSubcategoryValid && "border border-red-500 rounded-md"
              )}
            >
              <SubcategorySelector
                categories={categories}
                currentSubcategory={localSubcategory}
                onChange={(subcategory) => setLocalSubcategory({
                  id: subcategory.id,
                  name: subcategory.name
                })}
              />
            </div>
          </div>
        </div>

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
            <div className="relative flex items-center justify-center my-4">
              <hr className="w-full border-gray-300" />
              <span className="absolute px-2 text-sm text-gray-500 bg-white">AND</span>
            </div>
            <EditableCategorizationCondition
              key={condition.id}
              condition={condition}
              accounts={accounts}
              onUpdate={syncNewCondition}
              onDelete={() => handleDeleteNewCondition(condition.id)}
              setToDelete={false}
            />
          </div>
        ))}

        <div className="w-full flex justify-center mb-5">
          <AddConditionButton
            onClick={handleAddNewCondition}
          />
        </div>
      </div>

      {/* Action buttons (Delete, Cancel, Save) */}
      <div className="mt-7 flex justify-between" >
        {/* Delete Button: Separated on the left */}
        {isNewRule ? (<div></div>) : (
          <button
            onClick={() => setShowDeleteConfirm(true)}
            className={clsx(
              "flex items-center bg-red-400 text-white px-3 py-2",
              "rounded-md hover:bg-red-500"
            )}
          >
            <TrashIcon className="w-5 h-5 mr-1" />
            Delete
          </button>
        )}

        {/* Cancel and Save Buttons: Grouped on the right */}
        <div className="flex space-x-6">
          <button
            className="flex items-center text-gray-500 hover:text-gray-700"
            onClick={onCancel}
          >
            <ArrowUturnLeftIcon className="w-5 h-5 mr-1" />
            Cancel
          </button>

          <button
            className="flex items-center bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600"
            onClick={handleRuleSave}
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

      {error &&
        <ErrorNotification
          message={error}
          onClose={() => setError(null)}
        />
      }
    </div >
  );
}