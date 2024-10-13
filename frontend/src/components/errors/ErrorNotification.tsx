import clsx from "clsx";
import { useEffect } from "react";

interface ErrorNotificationProps {
  message: string;
  onClose: () => void;
}

export default function ErrorNotification({
  message, onClose
}: ErrorNotificationProps) {
  useEffect(() => {
    const timeout = setTimeout(() => {
      onClose(); // Auto-close after 3 seconds
    }, 3000);
    return () => clearTimeout(timeout); // Clear timeout on unmount
  }, [onClose]);

  return (
    <div
      className={clsx(
        "fixed bottom-4 right-4 p-4 bg-white border border-red-500",
        "rounded-lg shadow-lg text-red-600 flex items-center space-x-4",
        "transition-opacity duration-300"
      )}
    >
      <span>{message}</span>
      <button
        className="text-xl font-bold hover:text-red-700 focus:outline-none"
        onClick={onClose}
      >
        &times;
      </button>
    </div>
  );
};