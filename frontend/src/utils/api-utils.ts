export const getBaseApiUrl = () => {
  return process.env.NEXT_PUBLIC_API_BASE_URL || 'http://127.0.0.1:3005';
};