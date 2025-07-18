import { uuid } from "drizzle-orm/gel-core";
import { pgTable, serial, text, timestamp } from "drizzle-orm/pg-core";

export const users = pgTable("users",{
    id: uuid("id").primaryKey().defaultRandom(),
    name: text("name").notNull(),
    email: text("email").notNull().unique(),
    password: text("password").notNull(),
    createdAt: timestamp("created_at").defaultNow(),
    updatedAt: timestamp("updated_at").defaultNow(),
});
export type InsertUser = typeof users.$inferInsert;
export type NewUser = typeof users.$inferSelect;