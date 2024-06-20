import gradio as gr
from langchain_community.chat_models import ChatOllama
from langchain_community.document_loaders import WebBaseLoader
from langchain.text_splitter import CharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import OllamaEmbeddings
from langchain_core.runnables import RunnablePassthrough
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser


def process(urls, question):
    chat = ChatOllama(model="mistral")
    
    urls_list = urls.split("\n")
    
    docs = [WebBaseLoader(url).load() for url in urls_list]
    docs_list = [item for sublist in docs for item in sublist]
    text_splitter = CharacterTextSplitter.from_tiktoken_encoder(chunk_size=7500, chunk_overlap=100)
    doc_splits = text_splitter.split_documents(docs_list)

    vectorstore = Chroma.from_documents(
        documents=doc_splits, 
        collection_name="mini-rag",
        embedding=OllamaEmbeddings(model="nomic-embed-text")
    )

    retriever = vectorstore.as_retriever()
    
    after_rag_response_template = """Answer the question based only on the following context: 
    {context}
    Question: {question}
    """

    after_rag_prompt = ChatPromptTemplate.from_template(after_rag_response_template)

    after_rag_chain = (
        {"context": retriever, "question": RunnablePassthrough()}
        | after_rag_prompt
        | chat
        | StrOutputParser()
    )
    
    after_rag_chain.invoke(question)
    
# interface = gr.Interface(
#     fn=process,
#     inputs=[gr.Textbox(label="Enter URL separeted by new lines"), gr.Textbox(label="Question")],
#     outputs="text",
#     title="Documents Query with Ollama",
#     description="Enter URLs and a question to query the documents"
# )

interface = gr.Interface(fn=process,
                     inputs=[gr.Textbox(label="Enter URLs separated by new lines"), gr.Textbox(label="Question")],
                     outputs="text",
                     title="Document Query with Ollama",
                     description="Enter URLs and a question to query the documents.")

interface.launch()