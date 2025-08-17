import React from "react";

export default function UrlList() {
    const dummyUrls = [
        "http://api.example.com/login",
        "http://api.example.com/users",
        "http://admin.example.com/dashboard",
    ];

    return (
        <div>
            <h2 className="text-2xl font-bold mb-4">URLs</h2>
            <ul className="space-y-2">
                {dummyUrls.map((url, idx) => (
                    <li key={idx} className="bg-gray-800 p-3 rounded-lg shadow">
                        <a
                            href={url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-blue-400 hover:underline break-all"
                        >
                            {url}
                        </a>
                    </li>
                ))}
            </ul>
        </div>
    );
}
