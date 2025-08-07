import express from "express";
import authRouter from "./routes/auth";
import taskRouter from "./routes/task";
import helmet from "helmet";
import cors from "cors";

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
    origin: process.env.FRONTEND_URL || "http://localhost:8000",
    credentials: true
}));

app.use(express.json({ limit: '10mb' }));

// Security headers
app.use((req, res, next) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    next();
});

app.use("/auth",authRouter);
app.use("/tasks", taskRouter);



app.listen(8000, () => {
    console.log("Server is running on port 8000");
});

