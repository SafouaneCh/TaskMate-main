import { Router ,Request, Response} from "express";
import { db } from "../db";
import { users } from "../db/schema";
import { eq } from "drizzle-orm";
import bcryptjs from "bcryptjs";
import type { NewUser } from "../db/schema";

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

authRouter.get("/",(req,res) => {
    res.send("Hey there! from auth");
});
export default authRouter;