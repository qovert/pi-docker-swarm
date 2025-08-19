#!/usr/bin/env python3
import json
import sys
import re

def clean_dashboard(input_file, output_file):
    """Clean up the Node Exporter Full dashboard for our environment."""
    
    with open(input_file, 'r') as f:
        dashboard = json.load(f)
    
    # Remove template variables
    dashboard.pop('__inputs', None)
    dashboard.pop('__elements', None)
    
    # Remove datasource requirements (we'll provide our own)
    if '__requires' in dashboard:
        dashboard['__requires'] = [
            req for req in dashboard['__requires'] 
            if req.get('type') != 'datasource'
        ]
    
    # Set dashboard properties
    dashboard['id'] = None
    dashboard['uid'] = 'node-exporter-full'
    dashboard['title'] = 'Node Exporter Full - Pi Cluster'
    
    # Convert dashboard to string and replace datasource references
    dashboard_str = json.dumps(dashboard, indent=2)
    
    # Replace all datasource template variables
    dashboard_str = dashboard_str.replace('${DS_PROMETHEUS}', 'prometheus')
    dashboard_str = dashboard_str.replace('"datasource": "prometheus"', '"datasource": {"type": "prometheus", "uid": "prometheus"}')
    
    # Also handle any remaining datasource references
    dashboard_str = dashboard_str.replace('"datasource": "Prometheus"', '"datasource": {"type": "prometheus", "uid": "prometheus"}')
    dashboard_str = dashboard_str.replace('"datasource": {"type": "prometheus"}', '"datasource": {"type": "prometheus", "uid": "prometheus"}')
    
    # Parse back to JSON to ensure it's valid
    cleaned_dashboard = json.loads(dashboard_str)
    
    # Write cleaned dashboard
    with open(output_file, 'w') as f:
        json.dump(cleaned_dashboard, f, indent=2)
    
    print(f"✅ Dashboard cleaned and saved to {output_file}")
    print(f"📊 Panels count: {len(cleaned_dashboard.get('panels', []))}")
    print(f"🏷️  Title: {cleaned_dashboard.get('title', 'Unknown')}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 clean_dashboard.py <input_file> <output_file>")
        sys.exit(1)
    
    clean_dashboard(sys.argv[1], sys.argv[2])
