#!/usr/bin/env python3
"""
测试博客标题从主页设置获取功能
"""
import requests
import json

def test_homepage_settings_api():
    """测试主页设置 API"""
    base_url = "http://localhost:8000/api"

    # 测试获取主页设置
    url = f"{base_url}/homepage/settings"

    try:
        response = requests.get(url)
        print(f"状态码: {response.status_code}")

        if response.status_code == 200:
            data = response.json()
            print("主页设置数据:")
            print(json.dumps(data, indent=2, ensure_ascii=False))

            # 检查是否包含 header_title 字段
            if 'header_title' in data:
                print(f"✅ header_title 字段存在: '{data['header_title']}'")
            else:
                print("❌ header_title 字段不存在")

            # 测试更新主页标题
            test_title = "测试博客标题"
            update_data = {
                "header_title": test_title
            }

            update_response = requests.put(url, json=update_data)
            if update_response.status_code == 200:
                updated_data = update_response.json()
                if updated_data.get('header_title') == test_title:
                    print(f"✅ 标题更新成功: '{updated_data['header_title']}'")
                else:
                    print("❌ 标题更新失败")
            else:
                print(f"❌ 更新请求失败: {update_response.status_code}")

        else:
            print(f"请求失败: {response.text}")

    except requests.exceptions.ConnectionError:
        print("❌ 无法连接到服务器，请确保后端服务正在运行")
    except Exception as e:
        print(f"❌ 测试失败: {e}")

if __name__ == "__main__":
    test_homepage_settings_api()
