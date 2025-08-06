import {defineConfig} from "drizzle-kit";

export default defineConfig({
    dialect: "postgresql",
    schema: "./src/db/schema.ts",
    out: "./drizzle",
    dbCredentials: {
        connectionString: process.env.DATABASE_URL || "postgresql://postgres:test123@localhost:5432/mydb",
    }
}) 