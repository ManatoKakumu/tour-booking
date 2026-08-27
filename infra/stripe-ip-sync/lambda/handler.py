import json
import urllib.request
import boto3
import os
import ipaddress


ec2 = boto3.client("ec2")
PREFIX_LIST_ID = os.environ["PREFIX_LIST_ID"]

def handler(event, context):
    stripe_ips = get_stripe_ips()
    stripe_cidrs = set(collapse_cidrs(to_cidr_list(stripe_ips)))

    current_cidrs = get_current_entries(PREFIX_LIST_ID)

    to_add, to_remove = get_diff(stripe_cidrs, current_cidrs)
    if not to_add and not to_remove:
        return

    update_prefix_list(PREFIX_LIST_ID, to_add, to_remove)

def get_stripe_ips():
    url = "https://stripe.com/files/ips/ips_api.json"
    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read())
    return data["API"]

def to_cidr_list(ips):
    return [f"{ip}/32" for ip in ips]

def collapse_cidrs(cidrs):
    networks = [ipaddress.ip_network(cidr) for cidr in cidrs]
    collapsed = ipaddress.collapse_addresses(networks)
    return [str(net) for net in collapsed]

def get_current_entries(prefix_list_id):
    paginator = ec2.get_paginator("get_managed_prefix_list_entries")
    cidrs = set()
    for page in paginator.paginate(PrefixListId=prefix_list_id):
        for entry in page["Entries"]:
            cidrs.add(entry["Cidr"])
    return cidrs

def get_diff(stripe_cidrs, current_cidrs):
    to_add = stripe_cidrs - current_cidrs
    to_remove = current_cidrs - stripe_cidrs
    return to_add, to_remove

def update_prefix_list(prefix_list_id, to_add, to_remove):
    current_version = ec2.describe_managed_prefix_lists(
        PrefixListIds=[prefix_list_id]
    )["PrefixLists"][0]["Version"]

    ec2.modify_managed_prefix_list(
        PrefixListId=prefix_list_id,
        CurrentVersion=current_version,
        AddEntries=[{"Cidr": cidr} for cidr in to_add],
        RemoveEntries=[{"Cidr": cidr} for cidr in to_remove],
    )
