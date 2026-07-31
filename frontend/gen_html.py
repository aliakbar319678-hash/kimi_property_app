import json
from pathlib import Path
from graphify.build import build_from_json  # type: ignore
from graphify.export import to_html  # type: ignore

if __name__ == '__main__':
    extraction = json.loads(Path('graphify-out/.graphify_extract.json').read_text(encoding='utf-8'))
    analysis   = json.loads(Path('graphify-out/.graphify_analysis.json').read_text(encoding='utf-8'))
    labels     = json.loads(Path('graphify-out/.graphify_labels.json').read_text(encoding='utf-8'))

    G = build_from_json(
        extraction,
        root='c:\\all projects\\tenant-and-landlord-application-master\\tenant-and-landlord-application-master',
        directed=False
    )
    communities = {int(k): v for k, v in analysis['communities'].items()}
    int_labels  = {int(k): v for k, v in labels.items()}

    to_html(G, communities, 'graphify-out/graph.html', community_labels=int_labels)
    print("HTML generated: graphify-out/graph.html")
    size = Path('graphify-out/graph.html').stat().st_size
    print(f"File size: {size:,} bytes")
