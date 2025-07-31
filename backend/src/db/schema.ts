import { pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";

export const users = pgTable("users",{
    id: uuid("id").primaryKey().defaultRandom(),
    name: text("name").notNull(),
    email: text("email").notNull().unique(),
    phone: text("phone").notNull().unique(),
    password: text("password").notNull(),
    createdAt: timestamp("created_at").defaultNow(),
    updatedAt: timestamp("updated_at").defaultNow(),
});

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;

export const tasks = pgTable("tasks", {
    id: uuid("id").primaryKey().defaultRandom(),
    name: text("name").notNull(),
    description: text("description").notNull(),
    dueAt: timestamp("due_at").$defaultFn(() => new Date(Date.now() + 7*24*60*60*1000)),
    status: text("status").notNull().default("peding"),
    // onDelete: "cascade" means when the main table "users" was deleted, the uid should be deleted also
    uid: uuid("user_id").references(() => users.id, {
        onDelete: "cascade",
    }),
    createdAt: timestamp("created_at").defaultNow(),
    updatedAt: timestamp("updated_at").defaultNow(),
    contact: text("contact").default("null"),
});

export type Task = typeof tasks.$inferSelect;
export type NewTask = typeof tasks.$inferInsert;