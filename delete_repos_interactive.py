#!/usr/bin/env python3
"""
Script interativo para deletar repositórios GitHub
Permite selecionar quais repositórios deletar um por um
Requer um Personal Access Token (PAT) com permissão 'delete_repo'
"""

import requests
import sys

# ========== CONFIGURAÇÃO ==========
# 1. Gere um PAT em: https://github.com/settings/tokens
# 2. Garanta que o token tem a permissão 'delete_repo'
# 3. Cole o token abaixo
GITHUB_TOKEN = "seu_token_aqui"
GITHUB_USERNAME = "gomesdev007"

# ========== NÃO ALTERE ABAIXO DESTA LINHA ==========

BASE_URL = "https://api.github.com"
HEADERS = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github.v3+json"
}

def get_all_repos():
    """Obtém lista de todos os repositórios do usuário"""
    repos = []
    page = 1
    
    while True:
        url = f"{BASE_URL}/user/repos?per_page=100&page={page}&type=owner"
        response = requests.get(url, headers=HEADERS)
        
        if response.status_code != 200:
            print(f"❌ Erro ao obter repositórios: {response.status_code}")
            print(response.json())
            sys.exit(1)
        
        data = response.json()
        if not data:
            break
        
        repos.extend(data)
        page += 1
    
    return sorted(repos, key=lambda x: x['name'])

def delete_repo(repo_name):
    """Deleta um repositório específico"""
    url = f"{BASE_URL}/repos/{GITHUB_USERNAME}/{repo_name}"
    response = requests.delete(url, headers=HEADERS)
    
    if response.status_code == 204:
        return True
    else:
        print(f"   Erro: {response.status_code} - {response.text}")
        return False

def clear_screen():
    """Limpa a tela do terminal"""
    print("\033[2J\033[H", end="")

def print_menu(repos, selecionados, pagina=0, items_por_pagina=10):
    """Exibe o menu interativo"""
    clear_screen()
    total_paginas = (len(repos) + items_por_pagina - 1) // items_por_pagina
    
    print("=" * 70)
    print("🗑️  SELETOR DE REPOSITÓRIOS PARA DELETAR")
    print("=" * 70)
    print(f"\n📊 Total: {len(repos)} repositórios | Selecionados: {len(selecionados)}")
    print(f"Página {pagina + 1}/{total_paginas}\n")
    
    inicio = pagina * items_por_pagina
    fim = min(inicio + items_por_pagina, len(repos))
    
    for i, repo in enumerate(repos[inicio:fim], start=1):
        marcado = "✅" if repo['name'] in selecionados else "⬜"
        print(f"  {i}. {marcado} {repo['name']}")
    
    print("\n" + "=" * 70)
    print("COMANDOS:")
    print("  [1-9]    Selecionar/Desselecionar repositório")
    print("  [n]      Próxima página")
    print("  [p]      Página anterior")
    print("  [a]      Selecionar TODOS")
    print("  [l]      Limpar seleção")
    print("  [d]      DELETAR selecionados")
    print("  [s]      Sair sem deletar")
    print("=" * 70)

def main():
    """Função principal"""
    # Validação do token
    if GITHUB_TOKEN == "seu_token_aqui":
        print("\n❌ ERRO: Você precisa adicionar seu Personal Access Token!")
        print("\nPasso 1: Gere um token em https://github.com/settings/tokens")
        print("Passo 2: Edite este arquivo e coloque o token em: GITHUB_TOKEN = '....'")
        print("Passo 3: Execute este script novamente")
        sys.exit(1)
    
    # Obter repositórios
    print("📥 Obtendo lista de repositórios...")
    repos = get_all_repos()
    
    if not repos:
        print("✅ Você não possui nenhum repositório!")
        sys.exit(0)
    
    selecionados = set()
    pagina = 0
    items_por_pagina = 10
    
    while True:
        print_menu(repos, selecionados, pagina, items_por_pagina)
        
        comando = input("\n👉 Digite o comando: ").strip().lower()
        
        # Selecionar/Desselecionar repositório
        if comando.isdigit():
            idx = int(comando) - 1
            inicio = pagina * items_por_pagina
            if 0 <= idx < items_por_pagina:
                repo_idx = inicio + idx
                if repo_idx < len(repos):
                    repo_name = repos[repo_idx]['name']
                    if repo_name in selecionados:
                        selecionados.remove(repo_name)
                    else:
                        selecionados.add(repo_name)
        
        # Próxima página
        elif comando == 'n':
            if pagina < (len(repos) + items_por_pagina - 1) // items_por_pagina - 1:
                pagina += 1
        
        # Página anterior
        elif comando == 'p':
            if pagina > 0:
                pagina -= 1
        
        # Selecionar todos
        elif comando == 'a':
            selecionados = set(repo['name'] for repo in repos)
        
        # Limpar seleção
        elif comando == 'l':
            selecionados.clear()
        
        # Deletar selecionados
        elif comando == 'd':
            if not selecionados:
                print("\n⚠️  Nenhum repositório selecionado!")
                input("Pressione ENTER para continuar...")
                continue
            
            clear_screen()
            print("=" * 70)
            print("⚠️  REPOSITÓRIOS A DELETAR:")
            print("=" * 70)
            for repo_name in sorted(selecionados):
                print(f"  🗑️  {repo_name}")
            
            print("\n" + "=" * 70)
            confirmacao = input("\n⚠️  Digite 'DELETAR' para confirmar: ").strip()
            
            if confirmacao == "DELETAR":
                confirmacao2 = input("⚠️  Tem certeza? Digite 'SIM' para confirmar irreversivelmente: ").strip()
                if confirmacao2 == "SIM":
                    print("\n🗑️  Deletando repositórios...\n")
                    deletados = 0
                    erros = 0
                    
                    for repo_name in sorted(selecionados):
                        if delete_repo(repo_name):
                            print(f"✅ {repo_name} - DELETADO")
                            deletados += 1
                        else:
                            print(f"❌ {repo_name} - ERRO")
                            erros += 1
                    
                    print("\n" + "=" * 70)
                    print("📊 RESUMO:")
                    print(f"   ✅ Deletados: {deletados}")
                    print(f"   ❌ Erros: {erros}")
                    print("=" * 70)
                    
                    input("\nPressione ENTER para continuar...")
                    selecionados.clear()
                    pagina = 0
                else:
                    print("❌ Operação cancelada!")
                    input("Pressione ENTER para continuar...")
            else:
                print("❌ Operação cancelada!")
                input("Pressione ENTER para continuar...")
        
        # Sair
        elif comando == 's':
            print("\n👋 Encerrando...")
            sys.exit(0)

if __name__ == "__main__":
    main()
