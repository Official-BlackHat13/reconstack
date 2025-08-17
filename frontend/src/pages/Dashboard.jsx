import React, { useState } from "react";
import Sidebar from "../components/Sidebar";
import StatsCard from "../components/StatsCard";
import DomainForm from "../components/DomainForm";
import SubdomainList from "../components/SubdomainList";
import UrlList from "../components/UrlList";
import CveTable from "../components/CveTable";

export default function Dashboard({ onLogout }) {
    const [activeSection, setActiveSection] = useState("dashboard");

    return (
        <div className="flex h-screen bg-gray-900 text-white">
            <Sidebar activeSection={activeSection} setActiveSection={setActiveSection} />

            <main className="flex-1 p-6 overflow-y-auto">
                <div className="flex justify-between items-center mb-6">
                    <h1 className="text-3xl font-bold">Dashboard</h1>
                    <button
                        onClick={onLogout}
                        className="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-400 transition"
                    >
                        Logout
                    </button>
                </div>

                {activeSection === "dashboard" && (
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <StatsCard title="Total Domains" value="5" />
                        <StatsCard title="Total Subdomains" value="38" />
                        <StatsCard title="Total CVEs" value="12" />
                    </div>
                )}

                {activeSection === "add-domain" && <DomainForm />}
                {activeSection === "subdomains" && <SubdomainList />}
                {activeSection === "urls" && <UrlList />}
                {activeSection === "cves" && <CveTable />}
            </main>
        </div>
    );
}
