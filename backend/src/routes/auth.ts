import { Router ,Request, Response} from "express";
import { db } from "../db";
import { users } from "../db/schema";
import { eq } from "drizzle-orm";
import bcryptjs from "bcryptjs";
import type { NewUser } from "../db/schema";
import jwt from "jsonwebtoken";
import { auth, AuthRequest } from "../middleware/auth";

require('dotenv').config();

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

        // check if user already exists
        const existingUser = await db
        .select()
        .from(users)
        .where(eq(users.email, email));

        if (existingUser.length){
            res
            .status(400)
            .json({ msg: "User with the same email already exists!"});
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
        res.status(500).json({ error: e });
    }
});

interface LoginBody {
    email: string;
    password: string;
}



authRouter.post("/login", async (req: Request<{}, {}, LoginBody>, res: Response) => {
    try{
        // get req body
        const{email, password} = req.body;

        // check if user doesn't exist
        const [existingUser] = await db
        .select()
        .from(users)
        .where(eq(users.email, email));

        if (!existingUser){
            res
            .status(400)
            .json({ msg: "User with the same email does not exist!"});
            return;
        }

        //match password
        const isMatch = await bcryptjs.compare(password, existingUser.password);
        if(!isMatch){
            res
            .status(400)
            .json({ msg: "Invalid credentials!"});
            return;
        }
        
        let jwtSecret = process.env.JWT_SECRET;
       if (!jwtSecret) {
         throw new Error("JWT_SECRET is not defined in environment variables");
       }
       const token = jwt.sign({ id: existingUser.id }, jwtSecret);

        res.json({ user: existingUser, token });

        }catch (e) {
        res.status(500).json({ error: e });
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
        const verified = jwt.verify(token, jwtSecret);

        if(!verified) {
            res.json(false);
            return;
        }

        // get the user data if the token is valid
        const verifiedToken = verified as {id: string};

        const user = await db
        .select()
        .from(users)
        .where(eq(users.id, verifiedToken.id));

        if(!user) {
            res.json(false);
            return;
        }

        res.json(true);


    } catch (e) {
        res.status(500).json(false);
    }
})

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