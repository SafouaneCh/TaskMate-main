import { Router ,Request, Response} from "express";
import { db } from "../db";
import { users } from "../db/schema";
import { eq } from "drizzle-orm";
import bcryptjs from "bcryptjs";
import type { NewUser } from "../db/schema";
import jwt from "jsonwebtoken";
import { auth, AuthRequest } from "../middleware/auth";
import dotenv from "dotenv";

dotenv.config();

const authRouter = Router();

interface SignUpBody {
    name: string;
    email: string;
    password: string;
    phone: string;
}
authRouter.post("/signup", async (req: Request<{}, {}, SignUpBody>, res: Response) => {
    try{
        // get req body
        const{name, email, password, phone} = req.body;

        // Validate password strength
        if (password.length < 8) {
            res.status(400).json({ error: "Password must be at least 8 characters long" });
            return;
        }

        if (!/[A-Z]/.test(password)) {
            res.status(400).json({ error: "Password must contain at least one uppercase letter" });
            return;
        }

        if (!/[a-z]/.test(password)) {
            res.status(400).json({ error: "Password must contain at least one lowercase letter" });
            return;
        }

        if (!/\d/.test(password)) {
            res.status(400).json({ error: "Password must contain at least one number" });
            return;
        }

        // Validate phone number format (basic validation)
        if (!phone || phone.length < 8) {
            res.status(400).json({ error: "Phone number must be at least 8 characters long" });
            return;
        }

        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            res.status(400).json({ error: "Please provide a valid email address" });
            return;
        }

        // check if user already exists with same email
        const existingUserByEmail = await db
        .select()
        .from(users)
        .where(eq(users.email, email));

        if (existingUserByEmail.length){
            res
            .status(400)
            .json({ error: "User with the same email already exists!"});
            return;
        }

        // check if user already exists with same phone
        const existingUserByPhone = await db
        .select()
        .from(users)
        .where(eq(users.phone, phone));

        if (existingUserByPhone.length){
            res
            .status(400)
            .json({ error: "User with the same phone number already exists!"});
            return;
        }

        //hashed pwd
        const hashedPassword = await bcryptjs.hash(password, 8);

        //creating a new user and stored in db
        const newUser: NewUser = {
            name,
            email,
            phone,
            password: hashedPassword,
        };
        const [user] =await db.insert(users).values(newUser).returning();
        res.status(201).json(user);



    }catch (e) {
        console.error('Signup error:', e);
        
        // Check for specific database constraint violations
        if (e && typeof e === 'object' && 'code' in e) {
            const error = e as any;
            if (error.code === '23505') { // PostgreSQL unique constraint violation
                if (error.detail && error.detail.includes('email')) {
                    res.status(400).json({ error: "User with the same email already exists!" });
                    return;
                } else if (error.detail && error.detail.includes('phone')) {
                    res.status(400).json({ error: "User with the same phone number already exists!" });
                    return;
                }
            }
        }
        
        res.status(500).json({ error: "Internal server error" });
    }
});

interface LoginBody {
    email: string;
    password: string;
}



authRouter.post("/login", async (req: Request<{}, {}, LoginBody>, res: Response) => {
    try {
        const { email, password } = req.body;

        // check if user doesn't exist
        const [existingUser] = await db
            .select()
            .from(users)
            .where(eq(users.email, email));

        if (!existingUser) {
            res
                .status(401) // <-- Use 401 for unauthorized
                .json({ error: "User with this email does not exist! Please sign up." });
            return;
        }

        // match password
        const isMatch = await bcryptjs.compare(password, existingUser.password);
        if (!isMatch) {
            res
                .status(401) // <-- Use 401 for unauthorized
                .json({ error: "Invalid credentials! Please try again or reset your password." });
            return;
        }
        
        let jwtSecret = process.env.JWT_SECRET;
       if (!jwtSecret) {
         throw new Error("JWT_SECRET is not defined in environment variables");
       }
       const token = jwt.sign(
         { 
           id: existingUser.id,
           iat: Math.floor(Date.now() / 1000),
           exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60), // 24 hours
           iss: 'taskmate-api',
           aud: 'taskmate-client'
         }, 
         jwtSecret,
         { algorithm: 'HS256' }
       );

        res.json({ user: existingUser, token });

        }catch (e) {
        console.error('Login error:', e);
        res.status(500).json({ error: "Internal server error" });
    }
});

authRouter.post("/tokenIsValid", async(req, res) => {
    try {
        // get the header
        const token = req.header("x-auth-token");

        if(!token) {
            res.json(false);
            return;
        }

        const jwtSecret = process.env.JWT_SECRET;
        if (!jwtSecret) {
          throw new Error("JWT_SECRET is not defined in environment variables");
        }
        // verify if the token is valid
        // Note : jwt.verify returns a jwt.JwtPayload object
        const verified = jwt.verify(token, jwtSecret, { algorithms: ['HS256'] }) as {id: string, exp: number, iat: number, iss: string, aud: string};

        if(!verified) {
            res.json(false);
            return;
        }

        // Check if token is expired
        const currentTime = Math.floor(Date.now() / 1000);
        if (verified.exp && verified.exp < currentTime) {
            res.json(false);
            return;
        }

        // get the user data if the token is valid
        const verifiedToken = verified as {id: string};

        const user = await db
        .select()
        .from(users)
        .where(eq(users.id, verifiedToken.id));

        if(!user.length) {
            res.json(false);
            return;
        }

        res.json(true);

    } catch (e) {
        console.error('Token validation error:', e);
        res.status(500).json(false);
    }
});

authRouter.get("/", auth, async (req: AuthRequest, res: Response) => {
    try{
        if (!req.user) {
            res.status(401).json({error: "Unauthorized"});
            return;
        }

        const [user] = await db.select().from(users).where(eq(users.id, req.user));
        res.json({...user, token: req.token});

    }catch(e){
        res.status(500).json(false);
    }
});

export default authRouter;