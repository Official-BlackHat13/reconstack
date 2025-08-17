import React from "react";

export default function Sidebar({ activeSection, setActiveSection }) {
    const menuItems = [
        { key: "dashboard", label: "Dashboard" },
        { key: "add-domain", label: "Add Target Domain" },
        { key: "subdomains", label: "Subdomains" },
        { key: "urls", label: "URLs" },
        { key: "cves", label: "CVEs" },
    ];

    return (
        <aside className="w-64 bg-gray-800 h-full shadow-lg">
            <div className="p-6 text-2xl font-bold text-green-400">VulnScan</div>
            <nav className="mt-4">
                {menuItems.map((item) => (
                    <button
                        key={item.key}
                        onClick={() => setActiveSection(item.key)}
                        className={`block w-full text-left px-6 py-3 hover:bg-gray-700 ${
                            activeSection === item.key ? "bg-gray-700 text-green-400" : "text-gray-300"
                        }`}
                    >
                        {item.label}
                    </button>
                ))}
            </nav>
        </aside>
    );
}