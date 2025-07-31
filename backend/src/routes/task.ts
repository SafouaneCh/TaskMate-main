import { Router } from "express";
import { auth, AuthRequest } from "../middleware/auth";
import { NewTask, tasks, users } from "../db/schema";
import { db } from "../db";
import { eq } from "drizzle-orm";

require('dotenv').config();

const taskRouter = Router();


taskRouter.post("/", auth, async (req: AuthRequest, res) => {
    try {
        req.body = {...req.body, uid: req.user!};
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
        const allTasks = await db.select().from(tasks).where(eq(tasks.uid, req.user!));
        
        res.json(allTasks);

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