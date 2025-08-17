import React from "react";

export default function StatsCard({ title, value }) {
    return (
        <div className="bg-gray-800 rounded-2xl shadow-md p-6 text-center card-glow">
            <h2 className="text-lg font-semibold text-gray-300">{title}</h2>
            <p className="text-3xl font-bold text-green-400 mt-2">{value}</p>
        </div>
    );
}
