import { NextFunction, Request, Response } from "express";
import { UUID } from "crypto";
import { db } from "../db";
import jwt from "jsonwebtoken";
import { users } from "../db/schema";
import { eq } from "drizzle-orm";

export interface AuthRequest extends Request {
    user?: UUID;
    token?: string;
}

export const auth = async (req: AuthRequest, res: Response, next: NextFunction) => {

    try {
        // get the header
        const token = req.header("x-auth-token");

        if(!token) {
            res.status(401).json({error: "No token, authorization denied"});
            return;
        }

        const jwtSecret = process.env.JWT_SECRET;
        if (!jwtSecret) {
          throw new Error("JWT_SECRET is not defined in environment variables");
        }
        // verify if the token is valid
        // Note : jwt.verify returns a jwt.JwtPayload (id: string) object
        const verified = jwt.verify(token, jwtSecret, { algorithms: ['HS256'] }) as {id: UUID, exp: number, iat: number, iss: string, aud: string};

        if(!verified) {
            res.status(401).json({error: "Token verification failed"});
            return;
        }

        // Check if token is expired
        const currentTime = Math.floor(Date.now() / 1000);
        if (verified.exp && verified.exp < currentTime) {
            res.status(401).json({error: "Token has expired"});
            return;
        }

        // get the user data if the token is valid
        const verifiedToken = verified as {id: UUID};

        const [user] = await db
        .select()
        .from(users)
        .where(eq(users.id, verifiedToken.id));

        if(!user) {
            res.status(401).json({error: "user not found"});
            return;
        }

        req.user = verifiedToken.id;
        req.token = token;

        next();


    } catch (e) {
        res.status(500).json({error: "Server error"});
    }

}