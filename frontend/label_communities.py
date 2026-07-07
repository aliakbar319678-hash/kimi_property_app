import sys, json
from graphify.build import build_from_json
from graphify.cluster import score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.report import generate
from pathlib import Path

if __name__ == '__main__':
    extraction = json.loads(Path('graphify-out/.graphify_extract.json').read_text(encoding='utf-8'))
    detection  = json.loads(Path('graphify-out/.graphify_detect.json').read_text(encoding='utf-8'))
    analysis   = json.loads(Path('graphify-out/.graphify_analysis.json').read_text(encoding='utf-8'))

    G = build_from_json(extraction, root='c:\\all projects\\tenant-and-landlord-application-master\\tenant-and-landlord-application-master', directed=False)
    communities = {int(k): v for k, v in analysis['communities'].items()}
    cohesion = {int(k): v for k, v in analysis['cohesion'].items()}
    tokens = {'input': extraction.get('input_tokens', 0), 'output': extraction.get('output_tokens', 0)}

    labels = {
        0: "Windows Platform Layer",
        1: "iOS/macOS Cocoa Embedding",
        2: "Vendor State Management",
        3: "Payment & Lease Management",
        4: "Landlord & Home Dashboard State",
        5: "App Entry & GoRouter",
        6: "Landlord State Data Model",
        7: "Custom Painters & Animations",
        8: "Shared Screen Helpers",
        9: "Vendor Onboarding Screen",
        10: "Linux/GTK Platform Layer",
        11: "Landlord Bid Management",
        12: "App Theme & Styling",
        13: "User Profile Provider",
        14: "Auth State (Freezed)",
        15: "Vendor GPS & Job Details",
        16: "Shared Screen State",
        17: "Common UI Widgets",
        18: "Preferences Screen",
        19: "Maintenance Request Screen",
        20: "Employment Provider",
        21: "Home Dashboard Screen",
        22: "Payment Maintenance State",
        23: "Vendor Shell Navigation",
        24: "OTP Auth Screen",
        25: "Search & Filter Provider",
        26: "Employment Screen",
        27: "Create Work Order",
        28: "Notifications Screen",
        29: "Vendor Bid Submission",
        30: "Chat Details Screen",
        31: "Basic Profile Screen",
        32: "AI Smart Assistant",
        33: "Auth Provider & API Core",
        34: "Welcome Screen",
        35: "Home Dashboard & Search",
        36: "Property Details Screen",
        37: "API Client Core",
        38: "Landlord Maintenance Dashboard",
        39: "Chat List Screen",
        40: "Payment History Screen",
        41: "Landlord Shell Navigation",
        42: "Tenant Directory",
        43: "Windows Runner Main",
        44: "Landlord Post Job",
        45: "Tenant Shell Navigation",
        46: "Freezed State Patterns",
        47: "Landlord Financial Overview",
        48: "Auth Register Screen",
        49: "Maintenance Provider Actions",
        50: "Vendor Billing Screen",
        51: "Vendor Find Jobs",
        52: "Vendor My Bids",
        53: "Vendor Work Orders",
        54: "TL AppBar Widget",
        55: "TL Input Field Widget",
        56: "Web Manifest & PWA",
        57: "Post Job & Property State",
        58: "Screen Settings Provider",
        59: "Landlord Job Chat Room",
        60: "Property Portfolio Screen",
        61: "Request Tracking & Profile State",
        62: "Onboarding Progress Bar",
        63: "API Constants",
        64: "Profile & Notifications Screen",
        65: "Landlord Reports & Analytics",
        66: "Search Filter Screen",
        67: "Role Selection Screen",
        68: "Vendor Dashboard Screen",
        69: "Android Plugin Registration",
        70: "iOS LLDB Debug Helper",
        71: "Chat Detail Routes",
        72: "Bottom Navigation Bar",
        73: "Welcome Auth State",
        74: "Lease Summary State",
        75: "Maintenance Request State",
        76: "Payment History State",
        77: "Pay Rent State",
        78: "Chat Detail State",
        79: "Chat List State",
        80: "Notifications State",
        81: "User Profile State",
        82: "Bid Data Model",
        83: "OTP Auth State",
        84: "Chat Message Model",
        85: "Property Data Model",
        86: "Tenant Data Model",
        87: "Android MainActivity",
        88: "iOS Flutter Export Env",
        89: "macOS Flutter Export Env",
        90: "Android App Build Config",
        91: "Android Root Build Config",
        92: "Android Settings Config",
        93: "Null/String Node",
    }

    questions = suggest_questions(G, communities, labels)

    report = generate(G, communities, cohesion, labels, analysis['gods'], analysis['surprises'], detection, tokens,
                      'c:\\all projects\\tenant-and-landlord-application-master\\tenant-and-landlord-application-master',
                      suggested_questions=questions)
    Path('graphify-out/GRAPH_REPORT.md').write_text(report, encoding='utf-8')
    Path('graphify-out/.graphify_labels.json').write_text(
        json.dumps({str(k): v for k, v in labels.items()}, ensure_ascii=False), encoding='utf-8'
    )
    print('Report updated with community labels')
    print(f"Communities labeled: {len(labels)}")
