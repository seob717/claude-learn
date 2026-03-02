import type { MDXComponents } from 'mdx/types';
import CodeBlock from './CodeBlock';

/**
 * MDX 커스텀 컴포넌트 매핑
 */
export const mdxComponents: MDXComponents = {
  pre: ({ children, ...props }: React.ComponentPropsWithoutRef<'pre'>) => {
    const child = children as React.ReactElement<{ children: string; className?: string }>;
    if (child?.props?.children) {
      return (
        <CodeBlock className={child.props.className}>
          {child.props.children}
        </CodeBlock>
      );
    }
    return <pre {...props}>{children}</pre>;
  },

  code: ({ children, className, ...props }: React.ComponentPropsWithoutRef<'code'>) => {
    if (className) {
      return <code className={className} {...props}>{children}</code>;
    }
    return (
      <code className="rounded bg-card px-1.5 py-0.5 text-sm border border-line" {...props}>
        {children}
      </code>
    );
  },

  a: ({ href, children, ...props }: React.ComponentPropsWithoutRef<'a'>) => {
    const isExternal = href?.startsWith('http');
    return (
      <a
        href={href}
        target={isExternal ? '_blank' : undefined}
        rel={isExternal ? 'noopener noreferrer' : undefined}
        className="text-accent underline underline-offset-2 hover:opacity-80"
        {...props}
      >
        {children}
        {isExternal && <span className="ml-0.5 text-xs">↗</span>}
      </a>
    );
  },

  blockquote: ({ children, ...props }: React.ComponentPropsWithoutRef<'blockquote'>) => (
    <blockquote className="border-l-4 border-accent bg-card rounded-r-lg px-4 py-2 my-4" {...props}>
      {children}
    </blockquote>
  ),

  table: ({ children, ...props }: React.ComponentPropsWithoutRef<'table'>) => (
    <div className="overflow-x-auto mb-4">
      <table className="w-full border-collapse text-sm" {...props}>{children}</table>
    </div>
  ),

  th: ({ children, ...props }: React.ComponentPropsWithoutRef<'th'>) => (
    <th className="border border-line bg-card px-3 py-2 text-left font-semibold" {...props}>{children}</th>
  ),

  td: ({ children, ...props }: React.ComponentPropsWithoutRef<'td'>) => (
    <td className="border border-line px-3 py-2" {...props}>{children}</td>
  ),
};
