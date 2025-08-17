import React, { useState } from "react";

export default function DomainForm() {
    const [domain, setDomain] = useState("");
    const [domains, setDomains] = useState(["example.com", "hackerone.com"]);

    const handleSubmit = (e) => {
        e.preventDefault();
        if (!domain.trim()) return;
        setDomains((d) => Array.from(new Set([...d, domain.trim().toLowerCase()])));
        setDomain("");
    };

    return (
        <div className="space-y-6">
            <div className="bg-gray-800 p-6 rounded-2xl shadow-lg max-w-lg">
                <h2 className="text-xl font-bold mb-4">Add Target Domain</h2>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <input
                        type="text"
                        value={domain}
                        onChange={(e) => setDomain(e.target.value)}
                        placeholder="example.com"
                        className="w-full p-3 rounded-lg bg-gray-700 border border-gray-600 text-white focus:outline-none focus:ring-2 focus:ring-green-400"
                        required
                    />
                    <button
                        type="submit"
                        className="w-full bg-green-500 text-black font-semibold py-2 px-4 rounded-lg hover:bg-green-400 transition"
                    >
                        Add Domain
                    </button>
                </form>
            </div>

            <div className="bg-gray-800 p-6 rounded-2xl shadow-lg">
                <h3 className="text-lg font-semibold mb-4">All Domains</h3>
                <ul className="space-y-2">
                    {domains.map((d, i) => (
                        <li key={i} className="bg-gray-700/60 px-4 py-2 rounded">
                            {d}
                        </li>
                    ))}
                </ul>
            </div>
        </div>
    );
}
