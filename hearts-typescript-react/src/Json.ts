export type { Json };

type Json = null | string | number | boolean | Json[] | { [key: string]: Json };
