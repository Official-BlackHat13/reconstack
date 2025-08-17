import React from "react";

export default function CveTable() {
    const dummyCves = [
        { id: "CVE-2023-1234", url: "http://api.example.com", severity: "High" },
        { id: "CVE-2022-5678", url: "http://admin.example.com", severity: "Medium" },
        { id: "CVE-2021-9999", url: "http://old.example.com", severity: "Low" },
    ];

    const severityColor = (level) => {
        if (level === "High") return "text-red-400 font-bold";
        if (level === "Medium") return "text-yellow-400 font-semibold";
        if (level === "Low") return "text-green-400";
        return "text-gray-300";
    };

    return (
        <div>
            <h2 className="text-2xl font-bold mb-4">Detected CVEs</h2>
            <div className="overflow-x-auto">
                <table className="min-w-full bg-gray-800 rounded-lg overflow-hidden">
                    <thead>
                    <tr className="bg-gray-700">
                        <th className="px-4 py-2 text-left">CVE ID</th>
                        <th className="px-4 py-2 text-left">URL</th>
                        <th className="px-4 py-2 text-left">Severity</th>
                    </tr>
                    </thead>
                    <tbody>
                    {dummyCves.map((cve, idx) => (
                        <tr key={idx} className="border-b border-gray-700">
                            <td className="px-4 py-2">{cve.id}</td>
                            <td className="px-4 py-2">
                                <a
                                    href={cve.url}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="text-blue-400 hover:underline break-all"
                                >
                                    {cve.url}
                                </a>
                            </td>
                            <td className={`px-4 py-2 ${severityColor(cve.severity)}`}>
                                {cve.severity}
                            </td>
                        </tr>
                    ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
