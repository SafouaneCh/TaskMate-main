import { Router } from "express";
import { auth, AuthRequest } from "../middleware/auth";
import { NewTask, tasks, users } from "../db/schema";
import { db } from "../db";
import { eq, and, gte, lt } from "drizzle-orm";
import dotenv from "dotenv";

dotenv.config();

const taskRouter = Router();


taskRouter.post("/", auth, async (req: AuthRequest, res) => {
    try {
        // Combine date and time strings from frontend into a single Date object
        const dueAtDateTime = new Date(req.body.date + 'T' + req.body.time);
        req.body = {...req.body, dueAt: dueAtDateTime, uid: req.user!};
        //create a new task in db
        const newTask: NewTask = req.body;
        // calling properties
        const [task] = await db.insert(tasks).values(newTask).returning();
        
        res.status(201).json(task);

    } catch(e) {
        res.status(500).json({error: e});
    }

});

taskRouter.get("/", auth, async (req: AuthRequest, res) => {
    try {
        const { date } = req.query;
        
        // If date parameter is provided, filter tasks by date
        if (date && typeof date === 'string') {
            const targetDate = new Date(date);
            const startOfDay = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate());
            const endOfDay = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate() + 1);
            
            const taskResults = await db
                .select()
                .from(tasks)
                .where(
                    and(
                        eq(tasks.uid, req.user!),
                        gte(tasks.dueAt, startOfDay),
                        lt(tasks.dueAt, endOfDay)
                    )
                );
            
            res.json(taskResults);
        } else {
            // Get all tasks for the user
            const taskResults = await db
                .select()
                .from(tasks)
                .where(eq(tasks.uid, req.user!));
            
            res.json(taskResults);
        }

    } catch(e) {
        res.status(500).json({error: e});
    }

});

taskRouter.put("/:taskId", auth, async (req: AuthRequest, res) => {
    try {
        const { taskId } = req.params;
        const { name, description, date, time, priority, contact } = req.body;
        
        // Combine date and time strings from frontend into a single Date object
        const dueAtDateTime = new Date(date + 'T' + time);
        
        const [updatedTask] = await db
            .update(tasks)
            .set({
                name: name,
                description: description,
                dueAt: dueAtDateTime,
                priority: priority,
                contact: contact,
                updatedAt: new Date(),
            })
            .where(eq(tasks.id, taskId))
            .returning();
        
        res.json(updatedTask);

    } catch(e) {
        res.status(500).json({error: e});
    }

});

taskRouter.delete("/", auth, async (req: AuthRequest, res) => {
    try {
        const {taskId}: {taskId: string} = req.body;
        await db.delete(tasks).where(eq(tasks.id, taskId));
        
        res.json(true);

    } catch(e) {
        res.status(500).json({error: e});
    }

});

export default taskRouter;