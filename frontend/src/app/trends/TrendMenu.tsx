import clsx from 'clsx';

interface TrendMenuProps {
  trendOptions: TrendOption[];
  selectedTrend: {
    transactionType: string;
    trendType: string;
  };
  onTrendSelection: (transactionType: string, trendType: string) => void;
}

export type TrendOption = {
  transactionType: string;
  trendType: string[];
};

export default function TrendMenu({
  trendOptions,
  selectedTrend,
  onTrendSelection,
}: TrendMenuProps) {
  return (
    <div>
      <h2 className="text-lg font-bold mb-4">Select a Trend</h2>
      {trendOptions.map((trendOption) => (
        <div key={trendOption.transactionType} className="mb-6">
          <h3 className="font-semibold text-gray-700 text-xl mb-2">
            {trendOption.transactionType}
          </h3>
          <ul className="ml-4 space-y-2">
            {trendOption.trendType.map((trend) => (
              <li key={trend}>
                <button
                  className={clsx(
                    "w-full text-left p-2 rounded-md text-sm font-medium",
                    "transition duration-300",
                    selectedTrend.transactionType === trendOption.transactionType &&
                      selectedTrend.trendType === trend
                      ? "text-theme-drk-orange font-semibold border border-blue-700 shadow-lg"
                      : "text-gray-900 hover:underline"
                  )}
                  onClick={() => onTrendSelection(trendOption.transactionType, trend)}
                >
                  {trend}
                </button>
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
}