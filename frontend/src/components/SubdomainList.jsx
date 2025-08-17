import React from "react";

export default function SubdomainList() {
    const dummySubdomains = [
        { name: "api.example.com", status: 200 },
        { name: "admin.example.com", status: 403 },
        { name: "old.example.com", status: 500 },
    ];

    const getStatusColor = (code) => {
        if (code === 200) return "text-green-400";
        if (code === 403) return "text-yellow-400";
        if (code >= 500) return "text-red-400";
        return "text-gray-300";
    };

    return (
        <div>
            <h2 className="text-2xl font-bold mb-4">Subdomains</h2>
            <ul className="space-y-3">
                {dummySubdomains.map((sub, idx) => (
                    <li
                        key={idx}
                        className="flex justify-between bg-gray-800 p-4 rounded-lg shadow"
                    >
                        <a
                            href={`http://${sub.name}`}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="hover:underline text-blue-400"
                        >
                            {sub.name}
                        </a>
                        <span className={`font-semibold ${getStatusColor(sub.status)}`}>
              {sub.status}
            </span>
                    </li>
                ))}
            </ul>
        </div>
    );
}
