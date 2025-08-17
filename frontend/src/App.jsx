import React, { useState, useEffect } from "react";
import { Routes, Route, Navigate, useNavigate } from "react-router-dom";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";

export default function App() {
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const navigate = useNavigate();

    // Restore session on load
    useEffect(() => {
        const storedAuth = localStorage.getItem("isAuthenticated");
        if (storedAuth === "true") {
            setIsAuthenticated(true);
        }
    }, []);

    const handleLogin = (username, password) => {
        // Dummy creds (match your earlier requirement)
        if (username === "BlackHat13" && password === "Kali@143") {
            setIsAuthenticated(true);
            localStorage.setItem("isAuthenticated", "true");
            navigate("/dashboard");
        } else {
            alert("Invalid credentials");
        }
    };

    const handleLogout = () => {
        setIsAuthenticated(false);
        localStorage.removeItem("isAuthenticated");
        navigate("/");
    };

    return (
        <Routes>
            <Route path="/" element={<Login onLogin={handleLogin} />} />
            <Route
                path="/dashboard"
                element={
                    isAuthenticated ? (
                        <Dashboard onLogout={handleLogout} />
                    ) : (
                        <Navigate to="/" replace />
                    )
                }
            />
        </Routes>
    );
}
