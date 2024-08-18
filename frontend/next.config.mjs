/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'http',
        hostname: '127.0.0.1',
        port: '3005',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: '127.0.0.1',
        port: '3005',
        pathname: '/**',
      }
    ]
  },
  env: {
    NEXT_PUBLIC_API_BASE_URL: process.env.NEXT_PUBLIC_API_BASE_URL,
    NEXT_PUBLIC_PHIL: process.env.NEXT_PUBLIC_PHIL
  }
};

export default nextConfig;
