import json
from pathlib import Path

analysis = json.loads(Path('graphify-out/.graphify_analysis.json').read_text(encoding='utf-8'))
communities = analysis['communities']

sorted_communities = sorted(communities.items(), key=lambda x: -len(x[1]))
for cid, nodes in sorted_communities[29:38]:
    top = nodes[:5]
    print(f"Community {cid} ({len(nodes)} nodes): {top}")
