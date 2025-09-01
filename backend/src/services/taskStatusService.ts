import { db } from "../db";
import { tasks } from "../db/schema";
import { eq, and, lt, sql } from "drizzle-orm";

export class TaskStatusService {
    
    // Update task status with proper validation
    static async updateTaskStatus(taskId: string, userId: string, newStatus: string) {
        const validStatuses = ["pending", "in_progress", "completed", "cancelled", "overdue"];
        
        if (!validStatuses.includes(newStatus)) {
            throw new Error("Invalid status");
        }
        
        let updateData: any = {
            status: newStatus,
            updatedAt: new Date(),
        };
        
        // Handle completedAt timestamp
        if (newStatus === "completed") {
            updateData.completedAt = new Date();
        } else if (newStatus !== "completed" && newStatus !== "in_progress") {
            updateData.completedAt = null;
        }
        
        const [updatedTask] = await db
            .update(tasks)
            .set(updateData)
            .where(
                and(
                    eq(tasks.id, taskId),
                    eq(tasks.uid, userId)
                )
            )
            .returning();
        
        return updatedTask;
    }
    
    // Mark task as completed
    static async completeTask(taskId: string, userId: string) {
        return await this.updateTaskStatus(taskId, userId, "completed");
    }
    
    // Mark task as in progress
    static async startTask(taskId: string, userId: string) {
        return await this.updateTaskStatus(taskId, userId, "in_progress");
    }
    
    // Mark task as pending
    static async resetTask(taskId: string, userId: string) {
        return await this.updateTaskStatus(taskId, userId, "pending");
    }
    
    // Cancel task
    static async cancelTask(taskId: string, userId: string) {
        return await this.updateTaskStatus(taskId, userId, "cancelled");
    }
    
    // Get tasks by status
    static async getTasksByStatus(userId: string, status: string) {
        const validStatuses = ["pending", "in_progress", "completed", "cancelled", "overdue"];
        
        if (!validStatuses.includes(status)) {
            throw new Error("Invalid status");
        }
        
        return await db
            .select()
            .from(tasks)
            .where(
                and(
                    eq(tasks.uid, userId),
                    eq(tasks.status, status as any)
                )
            )
            .orderBy(tasks.dueAt);
    }
    
    // Get tasks with multiple statuses
    static async getTasksByStatuses(userId: string, statuses: string[]) {
        const validStatuses = ["pending", "in_progress", "completed", "cancelled", "overdue"];
        
        // Validate all statuses
        for (const status of statuses) {
            if (!validStatuses.includes(status)) {
                throw new Error(`Invalid status: ${status}`);
            }
        }
        
        return await db
            .select()
            .from(tasks)
            .where(
                and(
                    eq(tasks.uid, userId),
                    sql`${tasks.status} = ANY(${statuses})`
                )
            )
            .orderBy(tasks.dueAt);
    }
    
    // Get task statistics by status
    static async getTaskStatusStats(userId: string) {
        const stats = await db
            .select({
                status: tasks.status,
                count: sql<number>`count(*)`
            })
            .from(tasks)
            .where(eq(tasks.uid, userId))
            .groupBy(tasks.status);
        
        // Convert to object format
        const statsObject: { [key: string]: number } = {};
        stats.forEach(stat => {
            statsObject[stat.status] = stat.count;
        });
        
        return statsObject;
    }
    
    // Check and update overdue tasks
    static async checkAndUpdateOverdueTasks(userId: string) {
        const now = new Date();
        
        // Find tasks that are overdue (due date passed but still pending or in_progress)
        const overdueTasks = await db
            .select()
            .from(tasks)
            .where(
                and(
                    eq(tasks.uid, userId),
                    lt(tasks.dueAt, now),
                    sql`${tasks.status} IN ('pending', 'in_progress')`
                )
            );
        
        // Update overdue tasks
        if (overdueTasks.length > 0) {
            const taskIds = overdueTasks.map(task => task.id);
            
            await db
                .update(tasks)
                .set({
                    status: "overdue",
                    updatedAt: new Date(),
                })
                .where(
                    and(
                        eq(tasks.uid, userId),
                        sql`${tasks.id} = ANY(${taskIds})`
                    )
                );
        }
        
        return overdueTasks.length;
    }
    
    // Get overdue tasks
    static async getOverdueTasks(userId: string) {
        const now = new Date();
        
        return await db
            .select()
            .from(tasks)
            .where(
                and(
                    eq(tasks.uid, userId),
                    lt(tasks.dueAt, now),
                    sql`${tasks.status} IN ('pending', 'in_progress', 'overdue')`
                )
            )
            .orderBy(tasks.dueAt);
    }
    
    // Get completed tasks with completion time
    static async getCompletedTasks(userId: string) {
        return await db
            .select()
            .from(tasks)
            .where(
                and(
                    eq(tasks.uid, userId),
                    eq(tasks.status, "completed" as any)
                )
            )
            .orderBy(tasks.completedAt);
    }
    
    // Get task completion rate
    static async getTaskCompletionRate(userId: string) {
        const [totalTasks] = await db
            .select({ count: sql<number>`count(*)` })
            .from(tasks)
            .where(eq(tasks.uid, userId));
        
        const [completedTasks] = await db
            .select({ count: sql<number>`count(*)` })
            .from(tasks)
            .where(
                and(
                    eq(tasks.uid, userId),
                    eq(tasks.status, "completed" as any)
                )
            );
        
        const total = totalTasks?.count || 0;
        const completed = completedTasks?.count || 0;
        
        return {
            total,
            completed,
            rate: total > 0 ? (completed / total) * 100 : 0
        };
    }
}
