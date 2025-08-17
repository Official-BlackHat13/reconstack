import React, { useState } from "react";

export default function Login({ onLogin }) {
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");

    const [show, setShow] = useState(false);

    const handleSubmit = (e) => {
        e.preventDefault();
        onLogin(username, password);
    };

    return (
        <div className="min-h-screen bg-gray-900 flex items-center justify-center bg-grid relative overflow-hidden">
            {/* Glowing background blob */}
            <div className="absolute inset-0 pointer-events-none">
                <div className="absolute -top-32 -left-32 w-96 h-96 rounded-full blur-3xl opacity-40"
                     style={{ background: "radial-gradient(circle, rgba(34,197,94,0.5) 0%, rgba(34,197,94,0) 60%)" }} />
                <div className="absolute -bottom-20 -right-24 w-[28rem] h-[28rem] rounded-full blur-3xl opacity-40"
                     style={{ background: "radial-gradient(circle, rgba(16,185,129,0.45) 0%, rgba(16,185,129,0) 60%)" }} />
            </div>

            <div className="relative bg-gray-800/80 backdrop-blur-md p-8 rounded-2xl shadow-xl w-full max-w-md border border-gray-700">
                <h1 className="text-3xl font-extrabold text-center text-green-400 mb-6">
                    Sign in
                </h1>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div>
                        <label className="block text-gray-300 mb-1">Username</label>
                        <input
                            type="text"
                            value={username}
                            onChange={(e) => setUsername(e.target.value)}
                            placeholder="BlackHat13"
                            className="w-full px-4 py-2 rounded-lg bg-gray-700 border border-gray-600 text-white focus:outline-none focus:ring-2 focus:ring-green-400"
                            required
                        />
                    </div>

                    <div>
                        <label className="block text-gray-300 mb-1">Password</label>
                        <div className="relative">
                            <input
                                type={show ? "text" : "password"}
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                placeholder="••••••••"
                                className="w-full pr-12 px-4 py-2 rounded-lg bg-gray-700 border border-gray-600 text-white focus:outline-none focus:ring-2 focus:ring-green-400"
                                required
                            />
                            <button
                                type="button"
                                onClick={() => setShow((s) => !s)}
                                aria-label="Toggle password visibility"
                                className="absolute inset-y-0 right-0 px-3 text-gray-300 hover:text-white"
                            >
                                {show ? "🙈" : "👁️"}
                            </button>
                        </div>
                    </div>

                    <button
                        type="submit"
                        className="w-full bg-green-500 text-black font-semibold py-2 px-4 rounded-lg hover:bg-green-400 transition"
                    >
                        Login
                    </button>
                </form>
            </div>
        </div>
    );
}
