import time

# These are stubs so the API works now.
# Later, replace with real subprocess calls to: subfinder, amass, httpx, nuclei.

def enumerate_subdomains_stub(domain: str):
    # pretend subfinder+amass+httpx
    time.sleep(0.1)
    base = domain.replace(".", "-")
    sample = [
        {"name": f"api.{domain}", "status_code": 200},
        {"name": f"admin.{domain}", "status_code": 403},
        {"name": f"old.{domain}", "status_code": 500},
    ]
    return sample
